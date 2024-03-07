# Deploy with 'firebase deploy' or 'firebase deploy --only functions'

from firebase_admin import initialize_app, firestore, auth
from firebase_functions import firestore_fn, https_fn, options
import datetime

initialize_app()

@https_fn.on_call()
def record_points(req: https_fn.CallableRequest) -> any:
    """Calculates recording points and stores it in the firestore DB."""

    # Checking that the user is authenticated.
    if req.auth is None:
        # Throwing an HttpsError so that the client gets the error details.
        raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.FAILED_PRECONDITION,
                                  message="The function must be called while authenticated.")

    uid = req.auth.uid
    #uid = req.data['uid']
    email = req.auth.token.get('email', 'anonymous')
    #email = req.data['email']
    lastRecordingTime = req.data['lastTime']

    if lastRecordingTime is None:
        lastRecordingTime = datetime.datetime.now().strftime('%d/%m/%Y %I:%M %p')  # or some default value

    lastRecordingTime_datetime = datetime.datetime.strptime(lastRecordingTime, '%d/%m/%Y %I:%M %p')
    # print(lastRecordingTime_datetime)
    currentTime = datetime.datetime.now()
    # print(currentTime)
    timeDifference = currentTime - lastRecordingTime_datetime

    maxPoints = 480
    potentialPoints = min(timeDifference.total_seconds() // 60, 24 * 60)
    # print(potentialPoints)
    pointsEarned = min(maxPoints, potentialPoints)
    # print(pointsEarned)

    firestore_client = firestore.client()

    # Get a reference to the document in the "leaderboard" collection with the UID as the document ID
    user_doc_ref = firestore_client.collection('leaderboard').document(uid)

    # Get the snapshot of the document
    doc_snapshot = user_doc_ref.get()

    # Check if the document exists
    userPoints = 0
    if doc_snapshot.exists:
        # Extract the data from the document snapshot
        user_data = doc_snapshot.to_dict()
        userPoints = user_data['points']
        # print("User data:", user_data)

    points = pointsEarned + userPoints

    user_data = {
        'email': email,
        'points': points,
        'uid': uid
    }

    # Set the user data in the document
    user_doc_ref.set(user_data)

    # Push the new message into Cloud Firestore using the Firebase Admin SDK.
    #_, doc_ref = firestore_client.collection("leaderboard").add({"email": email, "points": int(points), "uid": uid})

    # Create a dictionary containing the response data
    return {
        'points': points,
    }

@https_fn.on_call()
def delete_user_data(req: https_fn.CallableRequest):
    """Delete the signed in user account and removes them from the leaderboard firestore DB."""

    # Checking that the user is authenticated.
    if req.auth is None:
        # Throwing an HttpsError so that the client gets the error details.
        raise https_fn.HttpsError(code=https_fn.FunctionsErrorCode.FAILED_PRECONDITION,
                                  message="The function must be called while authenticated.")

    uid = req.auth.uid
    firestore_client = firestore.client()

    # Get a reference to the document in the "leaderboard" collection with the UID as the document ID
    user_ref = firestore_client.collection('leaderboard').document(uid)

    # Delete the document from firestore DB
    user_ref.delete()

    # Delete user account from Firebase Authentication
    auth.delete_user(uid)