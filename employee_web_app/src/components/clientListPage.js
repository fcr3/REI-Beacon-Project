import React, {Component} from 'react';
import {connect} from 'react-redux';
import '../styles/clientlistpage.css';
import {getClients, selectClient, deleteUpdateStatus, deleteClient, addUpdatedClient} from '../redux/actions';
import ClientCell from './clientCell';
import {database, auth} from '../database/config';
import {withRouter} from 'react-router-dom';

class ClientListPage extends Component {
  constructor(props) {
    super(props);
    this.listenForNewClients = this.listenForNewClients.bind(this);
    this.goToEditPage = this.goToEditPage.bind(this);
    this.deleteClient = this.deleteClient.bind(this);
    this.state = {
      selected: this.props.selectedClient !== null
    };
  }

  componentDidMount() {
    this.props.getClients();
    this.listenForNewClients();
  }

  componentWillUnmount() {
    if (auth.currentUser === null || auth.currentUser === undefined) {return;}

    let email = auth.currentUser.email.split(".")[0] + "";
    var listenerArray = [database.ref('/Employees/' + email)];
    this.props.clients.forEach((val) => {
      listenerArray.push(database.ref('/Clients/' + val.id));
    });
    listenerArray.forEach((val) => {val.off();});
  }

  listenForNewClients() {
    let email = auth.currentUser.email.split(".")[0] + "";
    var listenerArray = [database.ref('/Employees/' + email)];
    listenerArray.forEach((val) => {val.off();});

    database.ref('/Employees/' + email).once('value').then(snapshot => {
      if (!snapshot || !snapshot.val()) {this.props.history.push('/');}
      else {
        let newListenerArray = [database.ref('/Employees/' + email)];
        let clients = snapshot.val().clientIds.split(",");
        clients.forEach((val) => {newListenerArray.push(database.ref('/Clients/' + val));});

        newListenerArray.forEach((val, index) => {
          if (index === 0) {
            val.on('value', (snapshot) => {
              this.props.getClients();
            });
          } else {
            val.on('value', (snapshot) => {
              if (!snapshot || !snapshot.val()) {this.props.getClients();}
              else {this.props.addUpdatedClient({...snapshot.val(), updated: "Updated"});}
            });
          }
        });
      }
    });
  }

  goToEditPage(client) {
    this.setState({selected: true});
    this.props.deleteUpdateStatus(client);
    this.props.selectClient(client);
    this.props.history.push('/Home/EditClient/' + client.id);
  }

  deleteClient(e, client) {
    e.preventDefault();
    e.stopPropagation();
    this.props.deleteClient(client, this.props.emp);
  }

  render() {
    let renderedClients = (<ClientCell client={{name: "No Clients Created"}} key={0} />);
    if (this.props.clients && this.props.clients.length !== 0) {
      renderedClients = this.props.clients.map((val, index) => {
        return (<ClientCell client={val} func={(e) => this.goToEditPage(val)}
                           del={(e) => this.deleteClient(e, val)} key={index} newAttr={val.updated}/>);
      });
    }
    return (
      <div className="clientlistpage">{renderedClients}</div>
    );
  }
}

function mapStateToProps(reduxState) {
  return {
    emp: reduxState.emp,
    clients: reduxState.clients,
    selectedClient: reduxState.selectedClient
  };
}

let functions = {getClients, selectClient, deleteUpdateStatus, deleteClient, addUpdatedClient}
export default connect(mapStateToProps, functions)(withRouter(props => <ClientListPage {...props} />));
