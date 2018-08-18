import {database, auth} from '../database/config';

export const LOADED = "LOADED";
export const DELETE = "DELETE";
export const GET_EMP = "GET_EMP";
export const GET_CLIENTS = "GET_CLIENTS";
export const SET_SEL_CL = "SET_SEL_CL";
export const UPDATE_CL = "UPDATE_CL";
export const ADD_CLIENT = "ADD_CLIENT";

function handleLoaded(status) {
  return {
    type: LOADED,
    status
  }
}

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
    client = null;
  }
  return {
    type: SET_SEL_CL,
    client
  }
}

function handleDeleteClient(client, clientIds) {
  if (client === undefined || client === null) {
    client = null;
  }
  if (clientIds === undefined || clientIds === null) {
    clientIds = null;
  }
  return {
    type: DELETE,
    client,
    clientIds
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

export function initialLoad(status = true) {
  return dispatch => {
    dispatch(handleLoaded(status));
  }
}

export function updateEmp(emp) {
  return dispatch => {
    if (auth.currentUser === null || auth.currentUser === undefined){
      dispatch(handleReceivedEmp(null));
    } else {
      let email = auth.currentUser.email.split(".")[0] + "";
      let reference = database.ref('/Employees/' + email );
      reference.set({...emp})
        .then((result) => {dispatch(handleReceivedEmp({...emp}));})
        .catch(error => {console.log(error);});
    }
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

export function deleteClient(client, emp) {
  return dispatch => {
    if (auth.currentUser === null || auth.currentUser === undefined) {
      dispatch(handleDeleteClient(null));
    } else {
      let email = auth.currentUser.email.split(".")[0] + "";
      var clientIDlist = emp.clientIds.split(",").filter((val) => val !== client.id);

      database.ref('/Clients/' + client.id).set(null, (error) => {
        if (error) {console.log(error);}
        else {
          database.ref('/Employees/' + email).set({...emp, clientIds: clientIDlist.join(",")}, (error) => {
            if (error) {console.log(error);}
            else {dispatch(handleDeleteClient(client, clientIDlist.join(",")));}
          });
        }
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

export function addClient(client, emp) {
  return dispatch => {
    if (auth.currentUser === null || auth.currentUser === undefined){
      dispatch(handleAddClient(null));
    } else {
      let reference = database.ref('/Clients').push();
      reference.set({...client, id: reference.key}, (error) => {
          if (error) {console.log(error);}
          let email = auth.currentUser.email.split(".")[0] + "";
          let clientIDlist = emp.clientIds.split(",");
          clientIDlist.push(reference.key);
          emp.clientIds = clientIDlist.join(",");
          database.ref('/Employees/' + email).set(emp, (error) => {
            if (error) {console.log(error);}
            dispatch(handleAddClient({...client, id: reference.key}));
          });
        });
    }
  }
}

export function addUpdatedClient(client) {
  return dispatch => {
    if (auth.currentUser === null || auth.currentUser === undefined) {
      dispatch(handleUpdatedClient(null));
    } else {
      dispatch(handleUpdatedClient(client));
    }
  }
}

export function updateClient(client) {
  return dispatch => {
    if (auth.currentUser === null || auth.currentUser === undefined) {
      dispatch(handleUpdatedClient(null));
    } else {
      database.ref('/Clients/' + client.id).set(client, (error) => {
        if (error) {console.log(error);}
        dispatch(handleUpdatedClient(client));
      });
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
            if (clients.length === clientIds.length) {
              clients.sort((a, b) => {
                if (a.date > b.date) {return 1;}
                else if (a.date < b.date){return -1;}
                else{
                  var Atime = a.time.split("-");
                  if (Atime[2] === "PM") {Atime[0] = parseInt(Atime, 10) + 12 + "";}
                  Atime = parseInt(Atime.slice(0, 2).join(""), 10);
                  var Btime = b.time.split("-");
                  if (Btime[2] === "PM") {Btime[0] = parseInt(Btime, 10) + 12 + "";}
                  Btime = parseInt(Btime.slice(0, 2).join(""), 10);

                  if (Atime > Btime) {return 1;}
                  else if (Atime < Btime) {return -1;}
                  else {return 0;}
                }
              });
              dispatch(handleReceivedClients(clients));
            }
          });  });  });  }
  };
}
