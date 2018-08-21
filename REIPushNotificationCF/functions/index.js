const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

// deploy: firebase deploy --only functions

exports.sendAssistanceNotification = functions.database.ref('/Assistance')
  .onUpdate((change, context) => {

    let token = admin.database().ref("/Employees/admin@reyeseng/token").once('value');
     //TODO: use dictionary from messages portion of database to clean up base

    return Promise.resolve(token).then(result => {
      let extractedToken = result.val();
      console.log(result.val());
      const payload = {
        notification: {
          title: "Attention Needed at the Front",
          message: "Please go to the front to assist someone. Thank you!"
        }
      };

      return admin.messaging().sendToDevice([extractedToken], payload);
    }).then(response => {
      console.log();
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.log(error);
        }
      });
      return null;
    }).catch(error => {return console.log(error);});
});

exports.sendWantsDrinkNotification = functions.database.ref('/Clients/{clientID}')
  .onUpdate((change, context) => {
    let emp = change.after.val().emp.split('.')[0];
    let token = admin.database().ref("/Employees/" + emp).once('value');
    if (change.before.val().drink !== change.after.val().drink) {
      return Promise.resolve(token).then(result => {
        let extractedToken = result.val().token;
        var drink = change.after.val().drink;
        drink = drink.charAt(0).toUpperCase() + drink.slice(1);

        const payload = {
          notification: {
            title: "Client wants " + drink,
            body: "Your client has requested a drink. Please prepare"
          }
        };

        return admin.messaging().sendToDevice([extractedToken], payload);
      }).then(response => {
        const tokensToRemove = [];
        response.results.forEach((result, index) => {
          const error = result.error;
          if (error) {console.log(error);}
        });
        return null;
      }).catch(error => {return console.log(error);});
    } else {return null;}
  });

exports.sendCheckInNotification = functions.database.ref('/Clients/{clientID}')
  .onUpdate((change, context) => {
    let emp = change.after.val().emp.split('.')[0];
    let token = admin.database.ref("/Employees/" + emp).once('value');
    if (change.before.val().checkedIn !== change.after.val().checkedIn && change.after.val().checkedIn === "Yes") {
      return Promise.resolve(token).then(result => {
        let extractedToken = result.val().token;

        const payload = {
          notification: {
            title: "Client has Checked In ",
            body: "Your client is ready for the meeting!"
          }
        };

        return admin.messaging().sendToDevice([extractedToken], payload);
      }).then(response => {
        const tokensToRemove = [];
        response.results.forEach((result, index) => {
          const error = result.error;
          if (error) {console.log(error);}
        });
        return null;
      }).catch(error => {return console.log(error);});
    } else {return null;}
  });

exports.sendLocationNotification = functions.database.ref('/Clients/{clientID}')
  .onUpdate((change, context) => {

    // extract emp
    let emp = change.after.val().emp.split('.')[0];

    // get emp token
    let token = admin.database().ref("/Employees/" + emp).once('value');

    // Tests:
    // console.log("client ID", context.params.clientID);
    // console.log("location", change.after.val().loc);

    if (change.before.val().loc !== change.after.val().loc) {
      //Changed Location
      return Promise.resolve(token).then(result => {
        let extractedToken = result.val().token;
        var location = change.after.val().loc;
        location = location.charAt(0).toUpperCase() + location.slice(1);

        // Tests:
        // console.log("Location changed");

        const payload = {
          notification: {
            title: "Client Location: " + location,
            body: "Your client has moved. Please prepare meeting room and ammenities"
          }
        };

        return admin.messaging().sendToDevice([extractedToken], payload);
      }).then(response => {
        const tokensToRemove = [];
        response.results.forEach((result, index) => {
          const error = result.error;
          if (error) {
            console.log(error);
          }
        });
        return null;
      }).catch(error => {
        return console.log(error);
      });

    } else {
      // Unchanged Location
      return null;
    }
  });
