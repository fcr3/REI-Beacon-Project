import React, {Component} from 'react';
import {connect} from 'react-redux';
import {Redirect} from 'react-router-dom';
import {auth, database} from '../database/config';
import {initialLoad, getEmp, eraseState} from '../redux/actions';
import '../styles/homepage.css';
import Navbar from './navbar';
import ClientListPage from './clientListPage';
import EditClientPage from './editClientPage';

/** load icon from Designerz Base **/

class HomePageEditActive extends Component {
  componentDidMount() {
    this.props.getEmp();
    this.props.initialLoad();

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

  componentWillUnmount() {
    let email = auth.currentUser ? auth.currentUser.email.split(".")[0] + "" : null;
    if (email === null) {return;}
    database.ref('/Employees/' + email).off();
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
          <EditClientPage />
        </div>
      </div>
    );
  }

}

function mapStateToProps(reduxState) {
  return {
    emp: reduxState.emp
  };
}

export default connect(mapStateToProps, {initialLoad, eraseState, getEmp})(HomePageEditActive);
