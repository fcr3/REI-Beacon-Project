import React, {Component} from 'react';
import {connect} from 'react-redux';
import {Redirect} from 'react-router-dom';
import {auth} from '../database/config';
import {initialLoad, getEmp} from '../redux/actions';
import '../styles/homepage.css';
import Navbar from './navbar';
import ClientListPage from './clientListPage';
import SettingsPage from './settingsPage';

/** load icon from Designerz Base **/

class HomePageSettingsActive extends Component {
  componentDidMount() {
    this.props.getEmp();
    this.props.initialLoad();
  }

  render() {
    if (auth.currentUser === null || auth.currentUser === undefined) {
      return (<Redirect to="/" />);
    }
    let classArray = ["displaycontainer", "shrink"];
    return (
      <div className="homepage">
        <Navbar />
        <div className={classArray.join(" ")}>
          <ClientListPage />
          <SettingsPage />
        </div>
      </div>
    );
  }

}

export default connect(() => {return {}}, {initialLoad, getEmp})(HomePageSettingsActive);
