import React, {Component} from 'react';
import {database} from '../database/config';
import {connect} from 'react-redux';
import '../styles/addclientpage.css';
import {getClients, updateClient, selectClient} from '../redux/actions';
import {Redirect, withRouter} from 'react-router-dom';

class EditClientPage extends Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
    this.updateClient = this.updateClient.bind(this);
    this.setupClientListener = this.setupClientListener.bind(this);
    this.state = {
      ...this.props.selected
    };
  }

  componentDidMount() {
    if (this.props.selected === null) {return;}
    this.setupClientListener()
  }

  componentWillUnmount() {
    this.props.selectClient(null);
    if (this.props.selected === null) {return;}
    database.ref('/Clients' + this.state.id).off()
  }

  componentWillReceiveProps(newProps) {
    this.props = {
      ...newProps
    };
    this.setState({
      ...newProps.selected
    });
    if (newProps.selected !== null) {
      this.setupClientListener(newProps.selected.id);
    }
  }

  setupClientListener(id = this.state.id) {
    database.ref('/Clients/' + id).on('value', (snapshot) => {
      if (snapshot.val() === null) {return;}
      else {
        this.props.getClients();
        this.setState({...snapshot.val()});
      }
    });

    database.ref('/Clients/' + id).on('child_removed', (snapshot) => {
      this.setState({...this.state, removed: true});
    });
  }

  handleChange(e, key) {
    let value = e.target.value;
    if (key === "time") {
      let timeArr = e.target.value.split(":").map((val) => {
        return val + "";
      });
      if (parseInt(timeArr[0], 10) > 12) {
        value = (parseInt(timeArr[0], 10) % 12) + "-" + timeArr[1] + "-PM";
      } else if (parseInt(timeArr[0], 10) === 0) {
        value = "12-" + timeArr[1] + "-AM";
      } else {
        value = timeArr[0] + "-" + timeArr[1] + "-AM";
      }
    }
    let copyState = {...this.state};
    copyState[key] = value;
    this.setState(copyState);
  }

  updateClient(e) {
    let client = {...this.state};
    delete client["listener"];
    this.props.updateClient(client);
    this.props.getClients();
  }

  render() {
    if (this.state.removed !== undefined) {return (<Redirect to="/Home" />);}

    let classArray1 = ["addclientcontainer"];
    let classArray2 = ["addclientform"];
    let classArray3 = ["addclientbutton"];
    let url = window.location.pathname + ""
    if (url.includes("/Home/EditClient")) {
      classArray1.push("appear");
    } else {
      //console.log(this.props.loaded);
      if (this.props.loaded) {
        classArray1.push("disappear");
        classArray2.push("hide");
        classArray3.push("hide");
      }
    }

    var time = this.state.time ? this.state.time.split("-") : null;
    if (time !== null && time[2] === "PM") {
      time[0] = parseInt(time[0], 10) + 12 + "";
    } else if (time !== null && time[0].length < 2) {
      time[0] = "0" + time[0];
    }
    time = this.state.time ? time.slice(0, 2).join(":") : "";

    return (
      <div id="addclientcontainer" className={classArray1.join(" ")}>
        <form className={classArray2.join(" ")}>
          Name: <input className="addclientfield" onChange={(e) => this.handleChange(e, "person")} type="text"
                       value={this.state.person}/><br/>
          Meeting Date: <input className="addclientfield" onChange={(e) => this.handleChange(e, "date")}
                               type="date" value={this.state.date}
                               required pattern="[0-9]{4}-[0-9]{2}-[0-9]{2}"/><br/>
          Meeting Time: <input className="addclientfield" onChange={(e) => this.handleChange(e, "time")}
                               type="time" value={time}/><br/>
          Meeting Room: <input className="addclientfield" onChange={(e) => this.handleChange(e, "room")} type="text"
                               value={this.state.room}/><br/>
          Meeting with: <input className="addclientfield" type="text" value={this.state.empName} readOnly={true}/><br/>
          Location: <input className="addclientfield" type="text" value={this.state.loc} readOnly={true}/><br/>
          Drink: <input className="addclientfield" type="text" value={this.state.drink} readOnly={true}/><br/>
          Checked In: <input className="addclientfield" type="text"value={this.state.checkedIn} readOnly={true}/><br/>
        </form>
        <div className={classArray3.join(" ")} onClick={this.updateClient}>Save Client</div>
      </div>
    );
  }
}

function mapStateToProps(reduxState) {
  return {
    selected: reduxState.selectedClient,
    loaded: reduxState.loaded
  };
}

let functions = {updateClient, getClients, selectClient}
export default connect(mapStateToProps, functions)(withRouter(props => <EditClientPage {...props} />));
