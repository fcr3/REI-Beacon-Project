import React, { Component } from 'react';
import './style/App.css';
import * as firebase from 'firebase';
import ClientInfoCell from "./models/ClientInfoCell";
import {PlaceHolderCell} from "./models/PlaceHolderCell";
import ServiceButton from "./models/ServiceButton";
import PicCarousel from "./models/PicCarousel";
import Particles from "react-particles-js";
import params from "./models/particleParams";

// deploy: npm run build -> firebase init -> firebase deploy

class App extends Component {
  constructor() {
    super();
    this.setClients = this.setClients.bind(this);
    this.setListeners = this.setListeners.bind(this);
    this.setContinuousListener = this.setContinuousListener.bind(this);
    this.setChildAddedListeners = this.setChildAddedListeners.bind(this);
    this.setChildRemovedListeners = this.setChildRemovedListeners.bind(this);
    this.setChildUpdatedListeners = this.setChildUpdatedListeners.bind(this);
    this.getDateInString = this.getDateInString.bind(this);
    this.setIndividualListener = this.setIndividualListener.bind(this);
    this.assistancePressed = this.assistancePressed.bind(this);
    this.handleResize = this.handleResize.bind(this);
    this.state = {
      clients: [],
      size: 0
    };
  }

  setClients() {
    return new Promise((resolve, reject) => {
      this.getDateInString = this.getDateInString.bind(this);
      const db = firebase.database().ref("Clients");
      db.orderByChild("date").equalTo(this.getDateInString()).once("value", snap => {
        let snapValue = snap.val();
        var clientArr = [];
        if (snapValue !== null) {
          for (let key in Object.keys(snapValue)) {
            let val = snapValue[Object.keys(snapValue)[key]];
            clientArr = [...clientArr, val];
          }
        }

        if (clientArr.length !== 0) {
          this.setState({
            clients: clientArr,
            size: clientArr.length
          });
          resolve();
        } else {
          reject();
        }
      });
    });
  }

  setListeners() {
    return new Promise((resolve, reject) => {
      if (this.state.size !== 0) {
        this.state.clients.forEach((clients) => {
          this.setIndividualListener(clients);
          return true;
        });
        resolve();
      } else {
        reject();
      }
    });
  }

  setIndividualListener(client, filterList = true) {
    const db = firebase.database().ref().child("Clients");
    let listenerNum = db.child(client.id).on("value", snap => {
      let snapValue = snap.val();
      if (snapValue !== null) {
        let otherId = snapValue.id;
        var clientArr = this.state.clients;
        clientArr = this.state.clients.filter((val) =>
            val.id !== otherId
        );

        let dateArr = snap.val().date.split("-");
        let dateStr = dateArr[1] + "/" + dateArr[2] + "/" + dateArr[0];
        var clientDate = new Date(dateStr);
        var todaysDate = new Date();

        if (clientDate.setHours(0,0,0,0) !== todaysDate.setHours(0,0,0,0)) {
          db.child(snapValue.id).off("value");
          this.setState({
            clients: clientArr,
            size: clientArr.length - 1
          });
          return;
        }


        var newClient = {...snapValue, listenerNum};
        this.setState({
          clients: [...clientArr, newClient],
          size: clientArr.length + 1
        });
      }
    });
  }

  setContinuousListener() {
    this.setChildAddedListeners();
    this.setChildUpdatedListeners();
    this.setChildRemovedListeners();
  }

  setChildUpdatedListeners() {
    const db = firebase.database();
    const listenerRef = db.ref().child('Clients');
    listenerRef.on('child_changed', snap => {
      let snapValue = snap.val();
      if (snapValue !== null && snapValue !== "Genesis Data") {
        let dateArr = snap.val().date.split("-");
        let dateStr = dateArr[1] + "/" + dateArr[2] + "/" + dateArr[0];
        var clientDate = new Date(dateStr);
        var todaysDate = new Date();

        var existsAlready = false;
        this.state.clients.forEach((val) => {
          if (val.person === snap.val().person) {
            existsAlready = true;
          }
        });

        if (clientDate.setHours(0,0,0,0) === todaysDate.setHours(0,0,0,0) && !existsAlready) {
          this.setIndividualListener(snapValue, false);
        }
      }
    });
  }

  setChildAddedListeners() {
    const db = firebase.database();
    const listenerRef = db.ref().child('Clients');
    listenerRef.on('child_added', snap => {
      let snapValue = snap.val();
      if (snapValue !== null && snapValue !== "Genesis Data") {
        let dateArr = snap.val().date.split("-");
        let dateStr = dateArr[1] + "/" + dateArr[2] + "/" + dateArr[0];
        var clientDate = new Date(dateStr);
        var todaysDate = new Date();

        var existsAlready = false;
        this.state.clients.forEach((val) => {
          if (val.person === snap.val().person) {
            existsAlready = true;
          }
        });

        if (clientDate.setHours(0,0,0,0) === todaysDate.setHours(0,0,0,0) && !existsAlready) {
          this.setIndividualListener(snapValue, false);
        }
      }
    });
  }

  setChildRemovedListeners() {
    const db = firebase.database();
    const listenerRef = db.ref().child('Clients');
    listenerRef.on('child_removed', snap => {
      let snapValue = snap.val();
      if (snapValue !== null) {
        let clientArr = this.state.clients.filter((val) =>
          val.id !== snap.val().id
        );
        this.setState({
            clients: clientArr,
            size: this.state.size - 1,
        });
      }
    });
  }

  getDateInString() {
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth() + 1; //January is 0!

    var yyyy = today.getFullYear();
    if (dd < 10){
      dd = '0' + dd;
    }
    if (mm < 10){
      mm = '0' + mm;
    }
    return yyyy + '-' + mm + '-' + dd;
  }

  handleResize() {
    if (window.innerWidth <= window.innerHeight) {
        this.forceUpdate();
    }
  }

  componentDidMount() {
    let email = "dashboard@client.com";
    let password = "eKd8H5OVMcWhS1S6okaAYTNC";

    firebase.auth().signInWithEmailAndPassword(email, password)
      .then((results) => {
        window.addEventListener("resize", this.handleResize);

        this.setClients().then(this.setListeners, () => {
          this.setState({
            clients: [...this.state.clients],
            size: this.state.size
          });
        }).then(this.setContinuousListener, () => {
          this.setState({
            clients: [...this.state.clients],
            size: this.state.size
          });
        });
      })
      .catch((error) => {
        // Handle Errors here.
        var errorCode = error.code;
        var errorMessage = error.message;
        console.log(errorCode, errorMessage);
      });
  }

  checkIn(id) {
    var otherClients = this.state.clients.filter((val) => val.id !== id);
    var client = this.state.clients.filter((val) => val.id === id)[0];
    delete client["checkedIn"];
    var copyClient = {...client, checkedIn: "Yes"};
    client = {...client, checkedIn: "Yes"};
    delete client["listenerNum"];
    const dbRef = firebase.database().ref().child("Clients");
    dbRef.child(client.id).set(client);
    this.setState({
      clients: [...otherClients, copyClient],
      size: this.state.size
    });
  }

  assistancePressed() {
    let db = firebase.database().ref().child("Assistance")
    db.push().set({message: "Help needed at the Front"}, function(error) {
      console.log(error)
    });
  }

  render() {
    let displayedClients = this.state.clients.filter((val) => {
        console.log(val.loc);
        return val.loc === 'elevator' || val.loc === 'front door';
    });
    var clientInfoCells = displayedClients.map((val) => (
      <ClientInfoCell client={val} id={val.id} func={(id) => this.checkIn(id)}/>
    ));
    if (displayedClients.length === 0) {
      clientInfoCells = ( <PlaceHolderCell client="" /> );
    }
    let button = (<ServiceButton className="serviceButton" func={() => this.assistancePressed()}/>);
    return (
      <div className="App">
        <div className="titleBackground">
          <h1 className="title">
            Welcome to Reyes Engineering, Inc.
          </h1>
        </div>
        <div className="dashboard">
          <div className="welcomeBoard">
            <PicCarousel />
            {window.innerWidth <= window.innerHeight ? button : null}
          </div>
          <div className="clientBoard">
            {clientInfoCells}
          </div>
        </div>
        <Particles
          className="particles"
          params={params}
        />
      </div>
    );
  }
}

export default App;
