import {LOADED, ERASE, DELETE, DEL_UP_ST, GET_EMP, GET_EMP_WITH_CURR, GET_CLIENTS, SET_SEL_CL, UPDATE_CL, ADD_CLIENT} from './actions';

const initialState = {
  emp: {},
  clients: [],
  loaded: false,
  selectedClient: null,
  updated: [],
  instance: ""
}

export default function reducer(state = initialState, action) {
  switch(action.type) {
    case LOADED:
      return {
        ...state,
        loaded: action.status
      }
    case ERASE:
      return initialState;
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
    case GET_EMP_WITH_CURR:
      return {
        ...state,
        emp: action.emp,
        instance: action.emp.current
      }
    case GET_CLIENTS:
      return {
        ...state,
        clients: [...action.clients],
        selectedClient: state.selectedClient
      };
    case (UPDATE_CL || ADD_CLIENT || DEL_UP_ST):
      let filterClients2 = state.clients.filter((val) => val.id !== action.client.id);
      filterClients2.push(action.client);
      filterClients2.sort((a, b) => {
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
        clients: filterClients2,
        selectedClient: state.selectedClient
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
