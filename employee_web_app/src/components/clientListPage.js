import React, {Component} from 'react';
import {connect} from 'react-redux';
import '../styles/clientlistpage.css';
import {getClients, updateClient, selectClient} from '../redux/actions';
import ClientCell from './clientCell';
import {Redirect} from 'react-router-dom';

class ClientListPage extends Component {

  componentDidMount() {
    this.props.getClients()
  }

  goToEditPage(client) {
    this.props.selectClient(client);
    return (<Redirect to="/Home/EditClient"/>);
  }

  render() {
    let renderedClients = (<ClientCell client={{name: "No Clients Created"}} key={0} />);
    if (this.props.clients.length !== 0) {
      renderedClients = this.props.clients.map((val, index) => (
        <ClientCell client={val} onClick={(e) => this.goToEditPage(val)} key={index} />
      ));
    }
    return (
      <div className="clientlistpage">{renderedClients}</div>
    );
  }
}

function mapStateToProps(reduxState) {
  return {clients: reduxState.clients};
}

let functions = {getClients, updateClient, selectClient}
export default connect(mapStateToProps, functions)(ClientListPage);
