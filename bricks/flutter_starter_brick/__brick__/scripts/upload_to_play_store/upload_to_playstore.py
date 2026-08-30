#!/usr/bin/env python3
"""
Upload AAB to Google Play Internal Testing track.
Uses Google Play Developer API v3 directly (no fastlane required).

Official Documentation:
- APKs and Tracks: https://developers.google.com/android-publisher/tracks
- Bundles Upload: https://developers.google.com/android-publisher/api-ref/rest/v3/edits.bundles/upload
- Upload Media: https://developers.google.com/android-publisher/upload

Workflow (from docs):
1. Open a new edit (Edits.insert)
2. Upload AAB using resumable upload (Edits.bundles.upload)
3. Assign to track (Edits.tracks.update)
4. Commit the edit (Edits.commit)

Usage:
    python upload_to_playstore.py <aab_path> <service_account_json_path>
        <package_name> <release_status>

Requires:
    pip install google-auth google-api-python-client
"""

import argparse
import errno
import random
import ssl
import sys
import time

from google.auth.exceptions import TransportError
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaFileUpload
from httplib2 import HttpLib2Error

SCOPES = ['https://www.googleapis.com/auth/androidpublisher']

# From docs - Track name table:
# "The internal testing track: 'internal'"
# https://developers.google.com/android-publisher/tracks
INTERNAL_TRACK = 'internal'

# Exponential backoff settings (from docs best practices)
MAX_RETRIES = 5
INITIAL_WAIT_SECONDS = 1
_RETRYABLE_OS_ERROR_CODES = {
    errno.ECONNABORTED,
    errno.ECONNREFUSED,
    errno.ECONNRESET,
    errno.EPIPE,
    errno.ETIMEDOUT,
}


def _is_retryable_transport_error(error):
    return isinstance(
        error,
        (
            TransportError,
            HttpLib2Error,
            ConnectionError,
            TimeoutError,
            ssl.SSLError,
        ),
    ) or (
        isinstance(error, OSError)
        and error.errno in _RETRYABLE_OS_ERROR_CODES
    )


def exponential_backoff_retry(func, *args, **kwargs):
    """
    Retry with exponential backoff for 5xx errors and connection interruptions.

    From docs (https://developers.google.com/android-publisher/upload):
    "Resume or retry uploads that fail due to connection interruptions or any 5xx errors"
    "Wait (2^n) + random_number_milliseconds, where n starts at 0"
    """
    for n in range(MAX_RETRIES + 1):
        try:
            return func(*args, **kwargs)
        except HttpError as e:
            if e.resp.status in [500, 502, 503, 504] and n < MAX_RETRIES:
                wait_time = INITIAL_WAIT_SECONDS * (2 ** n) + random.random()
                print(f"   Received {e.resp.status}, retrying in {wait_time:.1f}s...")
                time.sleep(wait_time)
            else:
                raise
        except (TransportError, HttpLib2Error, OSError) as e:
            if not _is_retryable_transport_error(e) or n >= MAX_RETRIES:
                raise
            wait_time = INITIAL_WAIT_SECONDS * (2 ** n) + random.random()
            print(
                f"   Connection interrupted ({type(e).__name__}), "
                f"retrying in {wait_time:.1f}s..."
            )
            time.sleep(wait_time)


def upload_to_internal_testing(
    aab_path: str,
    service_account_path: str,
    package_name: str,
    release_status: str,
) -> None:
    """
    Upload AAB to Google Play Internal Testing track.

    From docs (https://developers.google.com/android-publisher/tracks):
    1. "Open a new edit, as described in Edits Workflow"
    2. "Call the Edits.bundles.upload method" (for AAB files)
    3. "Call the Edits.tracks: update method for each track"
    4. "Call the Edits: commit method to commit the changes"
    """

    print(f"📦 Uploading {aab_path} to Google Play Internal Testing...")

    try:
        # Authenticate with service account and build the API client
        credentials = service_account.Credentials.from_service_account_file(
            service_account_path,
            scopes=SCOPES
        )
        service = build('androidpublisher', 'v3', credentials=credentials)

        # Step 1: Create a new edit
        # From docs: "Open a new edit"
        print("📝 Creating edit...")
        edit = exponential_backoff_retry(
            service.edits().insert(body={}, packageName=package_name).execute
        )
        edit_id = edit['id']
        print(f"   Edit ID: {edit_id}")

        # Step 2: Upload the AAB bundle using resumable upload
        # From docs (https://developers.google.com/android-publisher/upload):
        # "Resumable upload: uploadType=resumable. For reliable transfer,
        #  especially important with larger files."
        print("⬆️  Uploading AAB bundle (resumable upload)...")
        media = MediaFileUpload(
            aab_path,
            mimetype='application/octet-stream',
            resumable=True  # Uses resumable upload protocol
        )

        # From docs: Edits.bundles.upload for AAB files
        bundle_response = exponential_backoff_retry(
            service.edits().bundles().upload(
                packageName=package_name,
                editId=edit_id,
                media_body=media
            ).execute
        )

        version_code = bundle_response['versionCode']
        print(f"   Version code: {version_code}")

        # Step 3: Assign to internal testing track
        # From docs: "Call the Edits.tracks: update method"
        # Release format from docs:
        # {"releases": [{"versionCodes": ["88"], "status": "completed"}]}
        # Note: For draft apps (not yet published), use status: "draft"
        # From docs: "Draft releases allow you to automatically upload APKs and
        # create a release via the API which can later be deployed via the
        # Google Play Console."
        print(f"🎯 Assigning to '{INTERNAL_TRACK}' track...")
        track_body = {
            'track': INTERNAL_TRACK,
            'releases': [{
                'versionCodes': [str(version_code)],
                'status': release_status,
            }]
        }

        track_response = exponential_backoff_retry(
            service.edits().tracks().update(
                packageName=package_name,
                editId=edit_id,
                track=INTERNAL_TRACK,
                body=track_body
            ).execute
        )
        print(f"   Track: {track_response['track']}")

        # Step 4: Commit the edit
        # From docs: "Call the Edits: commit method to commit the changes.
        # After you do this, users on each track will be given the updated version"
        print("✅ Committing changes...")
        exponential_backoff_retry(
            service.edits().commit(packageName=package_name, editId=edit_id).execute
        )

        print(
            f"\n🎉 Successfully uploaded version {version_code} "
            f"with status {release_status}!"
        )
        if release_status == 'completed':
            print("   Note: It can take several hours for changes to take effect.")
        else:
            print("   The release remains a draft in Google Play Console.")

    except HttpError as e:
        print(f"\n❌ API Error: {e.resp.status} - {e.content.decode()}")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Upload failed: {e}")
        sys.exit(1)


def main():
    """Entry point for the upload script."""
    parser = argparse.ArgumentParser(
        description='Upload AAB to Google Play Internal Testing'
    )
    parser.add_argument('aab_path', help='Path to the AAB file')
    parser.add_argument('service_account_json', help='Path to service account JSON file')
    parser.add_argument('package_name', help='App package name (e.g., com.example.app)')
    parser.add_argument(
        'release_status',
        choices=('draft', 'completed'),
        help='Google Play release status',
    )

    args = parser.parse_args()

    upload_to_internal_testing(
        args.aab_path,
        args.service_account_json,
        args.package_name,
        args.release_status,
    )


if __name__ == '__main__':
    main()
