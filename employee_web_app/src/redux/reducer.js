import {GET_CLIENTS, GET_SEL_CL} from './actions';

const initialState = {
  clients: [],
  selectedClient: {
    name: "No clients available",
    date: "",
    time: ""
  }
}

export default function reducer(state = initialState, action) {
  switch(action.type) {
    case GET_CLIENTS:
      return {
        clients: [...action.clients],
        selectedClient: state.selectedClient
      };
    case GET_SEL_CL:
      return {
        clients: [...state.clients],
        selectedClient: action.client
      }
    default:
      return state;
  }
}
