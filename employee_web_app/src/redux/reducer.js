import {GET_EMP, GET_CLIENTS, SET_SEL_CL, UPDATE_CL, ADD_CLIENT} from './actions';

const initialState = {
  emp: {},
  clients: [],
  selectedClient: {
    name: "No clients available",
    date: "",
    time: ""
  }
}

export default function reducer(state = initialState, action) {
  switch(action.type) {
    case GET_EMP:
      return {
        ...state,
        emp: action.emp
      }
    case GET_CLIENTS:
      return {
        clients: [...action.clients],
        selectedClient: state.selectedClient
      };
    case ADD_CLIENT:
      return {
        clients: [...state.clients, action.client],
        selectClient: state.selectClient
      }
    case UPDATE_CL:
      let filterClients = state.clients.filter((val) => val.id !== action.client.id);
      filterClients.push(action.client);
      return {
        clients: filterClients,
        selectClient: state.selectedClient
      }
    case SET_SEL_CL:
      return {
        clients: [...state.clients],
        selectedClient: action.client
      }
    default:
      return state;
  }
}
