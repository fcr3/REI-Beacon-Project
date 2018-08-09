import React, {Component} from 'react';
import {connect} from 'react-redux';
import {Redirect} from 'react-router-dom';
import {auth} from '../database/config';
import {getEmp} from '../redux/actions';
import '../styles/homepage.css';
import Navbar from './navbar';
import ClientListPage from './clientListPage';
import AddClientPage from './makeNewClientPage';
import EditClientPage from './editClientPage';
import SettingsPage from './settingsPage';

/** load icon from Designerz Base **/

class HomePage extends Component {

  componentDidMount() {
    this.props.getEmp();
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
    loaded: reduxState.loaded
  };
}

export default connect(mapStateToProps, {getEmp})(HomePage);
