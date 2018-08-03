import React from 'react';
import ReactDOM from 'react-dom';
import './style/index.css';
import App from './App';
import * as firebase from 'firebase';
import registerServiceWorker from './registerServiceWorker';

var config = {
    apiKey: "AIzaSyD0BzL1Tblv5wE_lg4lEIV6v9mbK7Dt1OU",
    authDomain: "experimental-database-fcr3.firebaseapp.com",
    databaseURL: "https://experimental-database-fcr3.firebaseio.com",
    projectId: "experimental-database-fcr3",
    storageBucket: "experimental-database-fcr3.appspot.com",
    messagingSenderId: "264350328196"
  };

firebase.initializeApp(config);

ReactDOM.render(<App />, document.getElementById('root'));
registerServiceWorker();
