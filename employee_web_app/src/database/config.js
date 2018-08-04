import * as firebase from 'firebase';

var config = {
  apiKey: "AIzaSyD0BzL1Tblv5wE_lg4lEIV6v9mbK7Dt1OU",
  authDomain: "experimental-database-fcr3.firebaseapp.com",
  databaseURL: "https://experimental-database-fcr3.firebaseio.com",
  projectId: "experimental-database-fcr3",
  storageBucket: "experimental-database-fcr3.appspot.com",
  messagingSenderId: "264350328196"
};
firebase.initializeApp(config);

const database = firebase.database()
const auth = firebase.auth()
export {database, auth};
