import React, { Component } from 'react';
import logo from './assets/rei-white.png';
import {Route} from 'react-router-dom';
import SignInPage from './components/signInPage';
//import HomePage from './components/homePage';
//import MakeNewClientPage from './components/makeNewClientPage.js';
//import EditClientPage from './components/editClientPage.js';
//import Settings from './components/settingsPage.js';
import './styles/App.css';

class App extends Component {
  render() {
    /*
    <Route exact path="/Clients" component={HomePage} />
    <Route exact path="/MakeNewClient" component={MakeNewClientPage} />
    <Route exact path="/EditClient" component={EditClientPage} />
    <Route exact path="/Settings" component={Settings} />
    */

    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h1 className="App-title">Welcome to Reyes Engineering</h1>
        </header>
        <Route exact path="/" component={SignInPage} />
      </div>
    );
  }
}

export default App;
