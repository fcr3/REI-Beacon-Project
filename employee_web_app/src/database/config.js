import * as firebase from 'firebase';

var config = {

};
firebase.initializeApp(config);

const database = firebase.database()
const auth = firebase.auth()
export {database, auth};
