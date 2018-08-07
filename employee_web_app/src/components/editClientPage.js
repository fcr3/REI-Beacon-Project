import React, {Component} from 'react';
import {connect} from 'react-redux';
import '../styles/clientlistpage.css';
import {getClients, updateClient, selectClient} from '../redux/actions';
import ClientCell from './clientCell';
import {Redirect} from 'react-router-dom';

class EditClientPage extends Component {
  constructor(props) {
    super(props);
    this.state = {editableClient: {...this.props.selected}};
  }

  goToEditPage(client) {
    this.props.getClients();
    return (<Redirect to="/Home"/>);
  }

  render() {
    let meetingTime = (<input className="clientField" type="text" />);
    meetingTime.value = this.state.editableClient.time;
    let meetingDate = (<input className="clientField" type="text" />);
    meetingDate.value = this.state.editableClient.date;
    let meetingRoom = (<input className="clientField" type="text" />);
    meetingRoom.vale = this.state.editableClient.room;

    return (
      <div className="clienattrpage">
        <h3>{this.state.editableClient.person}</h3>
        <p>
          Meeting Date: {meetingDate} <br/>
          Meeting Time: {meetingTime} <br/>
          Meeting Room: {meetingRoom} <br/>
        </p>
      </div>
    );
  }
}

function mapStateToProps(reduxState) {
  return {selected: reduxState.selectedClient};
}

let functions = {getClients, updateClient}
export default connect(mapStateToProps, functions)(EditClientPage);
