import React, {Component} from 'react';
import {connect} from 'react-redux';
import {auth} from '../database/config';
import '../styles/addclientpage.css';
import {initialLoad, updateEmp, getEmp, eraseState} from '../redux/actions';
import {Redirect} from 'react-router-dom';

class SettingsPage extends Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
    this.updateEmp = this.updateEmp.bind(this);
    this.logOut = this.logOut.bind(this);
    this.state = {
      ...this.props.emp,
      name: this.props.emp.name ? this.props.emp.name : ''
    };
  }

  componentWillReceiveProps(newProps) {
    this.props = {
      ...newProps
    };
    this.setState({
      ...newProps.emp
    });
  }

  handleChange(e, key) {
    let copyState = {...this.state};
    copyState[key] = e.target.value;
    this.setState(copyState);
  }

  updateEmp(e) {
    this.props.updateEmp(this.state);
    this.props.getEmp();
  }

  logOut(e) {
    this.props.initialLoad(false);
    auth.signOut()
    .then(() => {
      this.props.eraseState();
      this.setState({
        loggedOut: true
      });
    })
    .catch(error => {
      console.log(error);
    });
  }

  render() {
    let classArray1 = ["addclientcontainer"];
    let classArray2 = ["addclientform"];
    let classArray3 = ["addclientbutton"];
    if (window.location.pathname + "" === "/Home/Settings") {
      classArray1.push("appear");
    } else {
      //console.log(this.props.loaded);
      if (this.props.loaded) {
        classArray1.push("disappear");
        classArray2.push("hide");
        classArray3.push("hide");
      }
    }

    let name = this.state.name;

    if (this.state.loggedOut !== undefined && this.state.loggedOut) {
      return (<Redirect to="/"/>)
    }

    return (
      <div id="addclientcontainer" className={classArray1.join(" ")}>
        <form className={classArray2.join(" ")}>
          Name: <input className="addclientfield" onChange={(e) => this.handleChange(e, "name")} type="text" value={name}/><br/>
        </form>
        <div className={classArray3.join(" ")} onClick={this.updateEmp}>Save</div>
        <div className={classArray3.join(" ")} onClick={this.logOut}>Log Out</div>
      </div>
    );
  }
}

function mapStateToProps(reduxState) {
  return {
    emp: reduxState.emp,
    loaded: reduxState.loaded
  };
}

export default connect(mapStateToProps, {initialLoad, updateEmp, getEmp, eraseState})(SettingsPage);
