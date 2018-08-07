import React, {Component} from 'react';
import {connect} from 'react-redux';
import {auth} from '../database/config';
import '../styles/addclientpage.css';
import {addClient} from '../redux/actions';
import {Redirect, withRouter} from 'react-router-dom';

class AddClientPage extends Component {
  constructor(props) {
    super(props);
    console.log(this.props.key);
    this.addClient = this.addClient.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.state = {
      person: "",
      date: "",
      time: "",
      room: ""
    };
  }

  handleChange(e, key) {
    if (key === "time") {
      let timeArr = key.split(":").map((val) => {
        return val + "";
      });
      if (parseInt(timeArr[0], 10) > 12) {
        key = (parseInt(timeArr[0], 10) % 12) + "-" + timeArr[1] + "-PM";
      } else if (parseInt(timeArr[0], 10) === 0) {
        key = "12-" + timeArr[1] + "-AM";
      } else {
        key = timeArr[0] + "-" + timeArr[1] + "-AM";
      }
    }
    let copyState = {...this.state};
    copyState[key] = e.target.value;
    this.setState(copyState);
  }

  addClient() {
    let client = {
      ...this.state,
      loc: "",
      drink: "",
      wantsDrink: "",
      checkedIn: "false",
      emp: auth.currentUser.email,
      empName: this.props.emp.name,
      visitedLocs: "",
      messages: ""
    }
    this.props.addClient(client);
  }

  render() {
    let classArray = ["addclientcontainer"]
    if (window.location.pathname + "" === "/Home/NewClient") {
      classArray.push("appear");
    } else {
      classArray.push("disappear");
    }

    return (
      <div className={classArray.join(" ")}>
        <form className="addclientform">
          Name: <input className="addclientfield" onChange={(e) => this.handleChange(e, "person")} type="text" /><br/>
          Meeting Date: <input className="addclientfield" onChange={(e) => this.handleChange(e, "date")} type="date" required pattern="[0-9]{4}-[0-9]{2}-[0-9]{2}"/><br/>
          Meeting Time: <input className="addclientfield" onChange={(e) => this.handleChange(e, "time")} type="time" /><br/>
          Meeting Room: <input className="addclientfield" onChange={(e) => this.handleChange(e, "room")} type="text" /><br/>
        </form>
        <div className="addclientbutton" onClick={this.addClient}>Add Client</div>
      </div>
    );
  }
}

function mapStateToProps(reduxState) {
  return {
    emp: reduxState.emp
  };
}

export default connect(mapStateToProps, {addClient})(withRouter(props => <AddClientPage {...props} />));
