import {database, auth} from '../database/config';

export const GET_EMP = "GET_EMP";
export const GET_CLIENTS = "GET_CLIENTS";
export const SET_SEL_CL = "SET_SEL_CL";
export const UPDATE_CL = "UPDATE_CL";
export const ADD_CLIENT = "ADD_CLIENT";

function handleReceivedEmp(emp) {
  if (emp === undefined || emp === null) {
    emp = {};
  }
  return {
    type: GET_EMP,
    emp
  }
}

function handleSelectedClient(client) {
  if (client === undefined || client === null) {
    client = {};
  }
  return {
    type: SET_SEL_CL,
    client
  }
}

function handleUpdatedClient(client) {
  if (client === undefined || client === null) {
    client = {};
  }
  return {
    type: UPDATE_CL,
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

function handleAddClient(client) {
  if (client === undefined || client === null) {
    client = {};
  }
  return {
    type: ADD_CLIENT,
    client
  }
}

export function getEmp() {
  return dispatch => {
    if (auth.currentUser === null || auth.currentUser === undefined) {
      dispatch(handleReceivedEmp(null));
    } else {
      let email = auth.currentUser.email.split(".")[0] + "";
      database.ref('/Employees/' + email).once('value').then((snap) => {
        if (snap.val() === null) {return}
        dispatch(handleReceivedEmp(snap.val()))
      });
    }
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

export function addClient(client) {
  return dispatch => {
    if (auth.currentUser === null || auth.currentUser === undefined){
      dispatch(handleAddClient(null));
    } else {
      let reference = database.ref('/Clients').push();
      reference.set({...client, id: reference.key})
        .then((result) => {dispatch(handleAddClient({...client, id: reference.key}));})
        .catch(error => {console.log(error);});
    }
  }
}

export function updateClient(client) {
  return dispatch => {
    if (auth.currentUser === null || auth.currentUser === undefined) {
      dispatch(handleUpdatedClient(null));
    } else {
      dispatch(handleUpdatedClient(client));
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
