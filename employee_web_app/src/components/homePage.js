import React, {Component} from 'react';
import {connect} from 'react-redux';
import {Redirect} from 'react-router-dom';
import {auth, database} from '../database/config';
import {getEmp, eraseState, getClients, getEmpAndUpdateCurrent} from '../redux/actions';
import '../styles/homepage.css';
import Navbar from './navbar';
import ClientListPage from './clientListPage';
import AddClientPage from './makeNewClientPage';
import EditClientPage from './editClientPage';
import SettingsPage from './settingsPage';

/** load icon from Designerz Base **/

class HomePage extends Component {

  componentDidMount() {
    if (this.props.instance !== "") {
      this.props.getEmp();
      let email = auth.currentUser ? auth.currentUser.email.split(".")[0] + "" : null;
      if (email === null) {return;}
      database.ref('/Employees/' + email).on('value', (snapshot) => {
        if (!this.props.emp) {return;}
        if (!snapshot || !snapshot.val() || snapshot.val().current !== this.props.emp.current) {
          auth.signOut()
            .then((result) => {
              this.props.eraseState();
              this.setState({loggedOut: true});
              this.props.history.push("/");
            })
            .catch((error) => {console.log(error);});
        }
      });
    }
    else {this.props.getEmpAndUpdateCurrent();}
    this.props.getClients();
  }

  componentWillUnmount() {
    let email = auth.currentUser ? auth.currentUser.email.split(".")[0] + "" : null;
    if (email === null) {return;}
    database.ref('/Employees/' + email).off();
  }

  render() {
    if (auth.currentUser === null || auth.currentUser === undefined) {
      return (<Redirect to="/" />);
    }

    let classArray = ["displaycontainer"];
    if (this.props.loaded) {
      classArray.push("grow");
    }
    if (window.location.pathname !== "/Home") {
      classArray.push("shrink");
    }

    return (
      <div className="homepage">
        <Navbar />
        <div className={classArray.join(" ")}>
          <ClientListPage />
          <AddClientPage />
          <EditClientPage />
          <SettingsPage />
        </div>
      </div>
    );
  }

}

function mapStateToProps(reduxState) {
  return {
    emp: reduxState.emp,
    instance: reduxState.instance,
    loaded: reduxState.loaded
  };
}

export default connect(mapStateToProps, {getEmp, getClients, eraseState, getEmpAndUpdateCurrent})(HomePage);
