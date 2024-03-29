# WasteMaterials
This is my first serious project with Native iOS Swift, XCode, Firebase, UITableView, UICollectionView, Social Auth, etc.


Firestore Database Rules:
```bash
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read: if true;
      allow create: if request.auth.uid != null;
      allow delete, update: if request.auth.uid == resource.data.userId;
    }
    match /favorites/{userId}/ids/{document} {
      allow read: if true;
      allow write: if request.auth.uid == userId;      
    }
    match /words/{word}/ids/{document} {
      allow read, write: if true;
    }
    match /geo/countries/{country}/{region}/{city}/{document} {
      allow read, write: if true;
    }
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth.uid == userId;      
    }
  }
}
```

Firebase Storage Rules:
```bash
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /images/{userId}/{image} {
      allow read: if true; 
      allow write: if request.auth.uid == userId;
    }
  }
}
```
