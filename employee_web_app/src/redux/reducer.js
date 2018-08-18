import {LOADED, DELETE, GET_EMP, GET_CLIENTS, SET_SEL_CL, UPDATE_CL, ADD_CLIENT} from './actions';

const initialState = {
  emp: {},
  clients: [],
  loaded: false,
  selectedClient: null
}

export default function reducer(state = initialState, action) {
  switch(action.type) {
    case LOADED:
      return {
        ...state,
        loaded: action.status
      }
    case DELETE:
      return {
        ...state,
        emp: {...state.emp, clientIds: action.clientIds},
        clients: state.clients.filter((val) => val.id !== action.client.id)
      }
    case GET_EMP:
      return {
        ...state,
        emp: action.emp
      }
    case GET_CLIENTS:
      return {
        ...state,
        clients: [...action.clients],
        selectedClient: state.selectedClient
      };
    case ADD_CLIENT:
      return {
        ...state,
        clients: [...state.clients, action.client],
        selectClient: state.selectClient
      }
    case UPDATE_CL:
      let filterClients = state.clients.filter((val) => val.id !== action.client.id);
      filterClients.push(action.client);
      filterClients.sort((a, b) => {
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
      return {
        ...state,
        clients: filterClients,
        selectClient: state.selectedClient
      }
    case SET_SEL_CL:
      return {
        ...state,
        clients: [...state.clients],
        selectedClient: action.client
      }
    default:
      return state;
  }
}
