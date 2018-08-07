import React, { Component } from 'react';
import {Route} from 'react-router-dom';
import SignInPage from './components/signInPage';
import HomePage from './components/homePage';
//import MakeNewClientPage from './components/makeNewClientPage.js';
//import EditClientPage from './components/editClientPage.js';
//import Settings from './components/settingsPage.js';

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
        <Route exact path="/" component={SignInPage} />
        <Route exact path="/Home" component={HomePage} />
        <Route exact path="/Home/NewClient" component={HomePage} />
      </div>
    );
  }
}

export default App;
