import {database, auth} from '../database/config';

export const GET_CLIENTS = "GET_CLIENTS";
export const GET_SEL_CL = "GET_SEL_CL";

function handleSelectedClient(client) {
  if (client === undefined || client === null) {
    client = [];
  }
  return {
    type: GET_SEL_CL,
    client
  }
}

function handleReceivedClients(clients) {
  if (clients === undefined || clients === null) {
    clients = [];
  }
  return {
    type: GET_CLIENTS,
    clients
  }
}

export function selectClient(client) {
  return dispatch => {
    if (auth.currentUser === null || auth.currentUser === undefined) {
      dispatch(handleSelectedClient(null));
    } else {
      dispatch(handleSelectedClient(client));
    }
  }
}

export function getClients() {
  return dispatch => {
    if (auth.currentUser === null || auth.currentUser === undefined){
      dispatch(handleReceivedClients(null));
    } else {
      let email = auth.currentUser.email.split(".")[0] + "";
      let clients = []
      var clientIds = []
      database.ref('/Employees/' + email).once('value').then(snapshot => {
        if (snapshot.val() === null) {return}
        clientIds = snapshot.val().clientIds.split(",");
        clientIds.forEach((child, index) => {
          database.ref('/Clients/' + child).once('value').then(snapshot => {
            if (snapshot.val() === null) {return}
            clients.push(snapshot.val());
            if (clients.length === clientIds.length) {dispatch(handleReceivedClients(clients))}
          });  });  });  }
  };
}
