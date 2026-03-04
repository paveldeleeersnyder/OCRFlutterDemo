# Demo Project

This is the repo for the demo project of how scanning a document to saving the details in the database should work.  
In this demo I use the flutter_doc_scanner package to read the documents out, the supabase package for saving the file in bucket storage, and http for making the request to the api.

This project requires four env keys, you can find them all in the .env-example file.

The app only works for android and IOS because of dependencies.  
You can run the app with `flutter run`