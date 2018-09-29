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
        clients.forEach((val) => {
          if (val === "Genesis") {return;}
          newListenerArray.push(database.ref('/Clients/' + val));
        });

        newListenerArray.forEach((val, index) => {
          if (index === 0) {
            val.on('value', (snapshot) => {
              if (!snapshot || !snapshot.val()) {return;}
              if (this.props.emp === null || this.props.emp === undefined) {return;}
              if (snapshot.val().clientIds !== this.props.emp.clientIds) {
                this.props.getClients();
              }
            });
          } else {
            val.on('value', (snapshot) => {
              if (!snapshot || !snapshot.val()) {return;}
              else {
                let client = this.props.clients.filter((val) => val.id === snapshot.val().id)[0];
                if (client === undefined || client === null) {return;}
                for (var key in snapshot.val()) {
                  if (client[key] !== snapshot.val()[key] && (key === "loc" || key === "drink")) {
                    this.props.addUpdatedClient({...snapshot.val(), updated: "Updated"});
                    return;
                  }
                }
                this.props.addUpdatedClient({...client, ...snapshot.val()});
              }
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
    database.ref('/Clients' + client.id).off();
    this.props.deleteClient(client, this.props.emp);
  }

  render() {
    let renderedClients = null;
    if (this.props.clients && this.props.clients.length !== 0) {
      renderedClients = this.props.clients.map((val, index) => {
        if (val.Genesis !== undefined) {return null;}
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
