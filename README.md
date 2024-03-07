I would like to note a few functional things:
- There are two user flows into the applicationP: 1. Create account through signup page, then login using that account 2. Login anonymously. 
- I ask the user for consent when creating an account with username/password, and don't ask for it again afterwards.
- When the user logs in, leaderboard is the first page they see. There they can chose whether or not they want to delete their data.
- I don't ask for consent if a user is logging in anonymously as they are anonymous meaning privacy is not a concern.
- I did not like the auto log in feature because I wanted to be able to test the app with multiple accounts. Here is further justification:
  - I think having no auto log in functionality is also a legitimate design as it is more secure. 
  - My banking application and airline applications make me log in every time.
  - If I allowed auto log in and someone had access to my phone, they could enter this app freely without credentials. This would be a privacy concern for me.
  - We ask for consent to record their data as that information is sensitive. We don't want just anyone to be able to see all of a user's logs and figure out their daily routine. This is private data.

I would like to note a few technical things:
- In my cloud firestore rules, I have only allowed read access to clients, and blocked write access: 
    service cloud.firestore {
        match /databases/{database}/documents {
            match /{document=**} {
                allow read: if true;
                allow write: if false;
            }
        }
    }
- I have two firebase functions in my main.py. Any write operation is covered by these two functions.
- The first function, record_points, takes care of the business logic and calculates the score for the user on the leaderboard. Also pushes to firestore.
- The second function, delete_user_data, allows the user to delete their data at any point of time while they are logged into the app.
- Deleting their data means they will no longer appear on the leaderboard and will be completely removed from firestore and firebase authentication.