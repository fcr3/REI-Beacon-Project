import React, {Component} from 'react';
import {connect} from 'react-redux';
import {auth} from '../database/config';
import '../styles/addclientpage.css';
import {addClient} from '../redux/actions';
import {Redirect} from 'react-router-dom';

class AddClientPage extends Component {
  constructor(props) {
    super(props);
    this.addClient = this.addClient.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.state = {
      person: "",
      date: "",
      time: "",
      room: ""
    };
  }

  componentWillReceiveProps(newProps) {
    this.props = {
      ...newProps
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

  addClient(e) {
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
    this.setState({
      ...this.state,
      submitted: true
    })
  }

  render() {
    let classArray1 = ["addclientcontainer"];
    let classArray2 = ["addclientform"];
    let classArray3 = ["addclientbutton"];
    if (window.location.pathname + "" === "/Home/NewClient") {
      classArray1.push("appear");
    } else {
      //console.log(this.props.loaded);
      if (this.props.loaded) {
        classArray1.push("disappear");
        classArray2.push("hide");
        classArray3.push("hide");
      }
    }

    if (this.state.submitted !== undefined && this.state.submitted) {
      return (<Redirect to="/Home"/>)
    }

    return (
      <div id="addclientcontainer" className={classArray1.join(" ")}>
        <form className={classArray2.join(" ")}>
          Name: <input className="addclientfield" onChange={(e) => this.handleChange(e, "person")} type="text" /><br/>
          Meeting Date: <input className="addclientfield" onChange={(e) => this.handleChange(e, "date")} type="date" required pattern="[0-9]{4}-[0-9]{2}-[0-9]{2}"/><br/>
          Meeting Time: <input className="addclientfield" onChange={(e) => this.handleChange(e, "time")} type="time" /><br/>
          Meeting Room: <input className="addclientfield" onChange={(e) => this.handleChange(e, "room")} type="text" /><br/>
        </form>
        <div className={classArray3.join(" ")} onClick={this.addClient}>Add Client</div>
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

export default connect(mapStateToProps, {addClient})(AddClientPage);
