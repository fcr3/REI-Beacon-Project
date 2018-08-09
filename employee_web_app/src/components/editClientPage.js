import React, {Component} from 'react';
import {connect} from 'react-redux';
import '../styles/addclientpage.css';
import {getClients, addClient, selectClient} from '../redux/actions';

class EditClientPage extends Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
    this.state = {...this.props.selected};
  }

  componentWillUnmount() {
    this.props.selectClient(null);
  }

  componentWillReceiveProps(newProps) {
    this.props = {
      ...newProps
    };
    this.setState({
      ...newProps.selected
    });
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
    let client = {...this.state};
    this.props.addClient(client);
    this.props.getClients();
  }

  render() {
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

    return (
      <div id="addclientcontainer" className={classArray1.join(" ")}>
        <form className={classArray2.join(" ")}>
          Name: <input className="addclientfield"
                       onChange={(e) => this.handleChange(e, "person")}
                       type="text"
                       value={this.state.person}/><br/>
          Meeting Date: <input className="addclientfield"
                               onChange={(e) => this.handleChange(e, "date")}
                               type="date"
                               value={this.state.date}
                               required pattern="[0-9]{4}-[0-9]{2}-[0-9]{2}"/><br/>
          Meeting Time: <input className="addclientfield"
                               onChange={(e) => this.handleChange(e, "time")}
                               type="time" /><br/>
          Meeting Room: <input className="addclientfield"
                               onChange={(e) => this.handleChange(e, "room")}
                               type="text"
                               value={this.state.room}/><br/>
          Meeting with: <input className="addclientfield"
                               type="text"
                               value={this.state.empName}
                               readOnly={true}/><br/>
          Location: <input className="addclientfield"
                           type="text"
                           value={this.state.loc}
                           readOnly={true}/><br/>
          Drink: <input className="addclientfield"
                        type="text"
                        value={this.state.drink}
                        readOnly={true}/><br/>
          Checked In: <input className="addclientfield"
                             type="text"
                             value={this.state.checkedIn}
                             readOnly={true}/><br/>
        </form>
        <div className={classArray3.join(" ")} onClick={this.addClient}>Save Client</div>
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

let functions = {addClient, getClients, selectClient}
export default connect(mapStateToProps, functions)(EditClientPage);
