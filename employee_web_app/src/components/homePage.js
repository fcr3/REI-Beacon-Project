import React, {Component} from 'react';
import {connect} from 'react-redux';
import {Route, Redirect, Switch, withRouter} from 'react-router-dom';
import {auth} from '../database/config';
import {getEmp} from '../redux/actions';
import '../styles/homepage.css';
import Navbar from './navbar';
import ClientListPage from './clientListPage';
import AddClientPage from './makeNewClientPage';
import EditClientPage from './editClientPage';

class HomePage extends Component {

  componentDidMount() {
    this.props.getEmp();
  }

  render() {
    if (auth.currentUser === null || auth.currentUser === undefined) {
      return (<Redirect to="/" />);
    }

    let classArray = ["displaycontainer"];
    if (window.location.pathname + "" === "/Home") {
      classArray.push("grow");
    } else {
      classArray.push("shrink")
    }

    var addComponent = (<AddClientPage />);
    var editComponent = ((<EditClientPage />))

    return (
      <div className="homepage">
        <Navbar />
        <div className={classArray.join(" ")}>
          <ClientListPage />
          {addComponent}
        </div>
      </div>
    );
  }

}

export default connect(() => {return {}}, {getEmp})(withRouter(props => <HomePage {...props} />));
