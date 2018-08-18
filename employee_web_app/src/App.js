import React, { Component } from 'react';
import {Route} from 'react-router-dom';
import SignInPage from './components/signInPage';
import MenuPage from './components/menuPage';
import HomePage from './components/homePage';
import HomePageAddActive from './components/homePageAddActive';
import HomePageEditActive from './components/homePageEditActive';
import HomePageSettingsActive from './components/homePageSettingsActive';
//import Settings from './components/settingsPage.js';

class App extends Component {
  render() {
    return (
      <div className="App">
        <Route exact path="/" component={SignInPage} />
        <Route exact path="/Menu" component={MenuPage} />
        <Route exact path="/Home" component={HomePage} />
        <Route exact path="/Home/NewClient" component={HomePageAddActive} />
        <Route exact path="/Home/EditClient/:id" component={HomePageEditActive} />
        <Route exact path="/Home/Settings" component={HomePageSettingsActive} />
      </div>
    );
  }
}

export default App;
