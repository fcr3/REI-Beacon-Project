import React, {Component} from 'react';
import {connect} from 'react-redux';
import '../styles/clientlistpage.css';
import {getClients, selectClient} from '../redux/actions';
import ClientCell from './clientCell';
import {Redirect, withRouter} from 'react-router-dom';

class ClientListPage extends Component {
  constructor(props) {
    super(props);
    this.goToEditPage = this.goToEditPage.bind(this);
    this.state = {
      selected: this.props.selectedClient !== null
    };
  }

  componentDidMount() {
    this.props.getClients()
  }

  goToEditPage(client) {
    this.setState({selected: true});
    this.props.selectClient(client);
    this.props.history.push('/Home/EditClient/' + client.id);
  }

  render() {
    let renderedClients = (<ClientCell client={{name: "No Clients Created"}} key={0} />);
    if (this.props.clients.length !== 0) {
      renderedClients = this.props.clients.map((val, index) => (
        <ClientCell client={val} func={(e) => this.goToEditPage(val)} key={index} />
      ));
    }
    return (
      <div className="clientlistpage">{renderedClients}</div>
    );
  }
}

function mapStateToProps(reduxState) {
  return {
    clients: reduxState.clients,
    selectedClient: reduxState.selectedClient
  };
}

let functions = {getClients, selectClient}
export default connect(mapStateToProps, functions)(withRouter(props => <ClientListPage {...props} />));
