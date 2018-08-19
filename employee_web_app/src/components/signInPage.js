import React, {Component} from 'react';
import {connect} from 'react-redux';
import {auth} from '../database/config';
import logo from '../assets/rei-white.png';
import '../styles/App.css';
import '../styles/signIn.css';
import { Redirect } from 'react-router-dom';

class SignInPage extends Component {
  constructor(props) {
    super(props);
    this.signIn = this.signIn.bind(this);
    this.handleEmailInput = this.handleEmailInput.bind(this);
    this.handlePasswordInput = this.handlePasswordInput.bind(this);
    this.state = {email: "", password: "", error: false};
  }

  componentDidMount() {
    auth.signOut().catch(error => {
      console.log(error);
    });
  }

  signIn() {
    console.log("Entered Sign In");
    auth.signInWithEmailAndPassword(this.state.email, this.state.password)
    .then((result) => {
      console.log("Sign In Successful");
      this.setState({...this.state, error: false});
    })
    .catch((error) => {
      console.log("Sign In Unsuccessful");
      this.setState({...this.state, error: true});
    });
  }

  handleEmailInput(e) {
    this.setState({...this.state, email: e.target.value});
  }

  handlePasswordInput(e) {
    this.setState({...this.state, password: e.target.value});
  }

  render() {
   if (auth.currentUser != null && !this.state.error) {return (<Redirect to="/Home" />)}
   return (
     <div className="formContainer">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <h1 className="App-title">Welcome to Reyes Engineering</h1>
      </header>
      <form className="form">
        <h3>Username:</h3> <input className="textField" onChange={this.handleEmailInput} type="text"/> <br/> <br/>
        <h3>Password:</h3> <input className="textField" onChange={this.handlePasswordInput} type="text"/> <br/>
      </form>
      <div className="signInButton" onClick={(e) => this.signIn()}>
        Sign In
      </div>
     </div>
   );
  }
}

export default connect(() => {return {}}, {})(SignInPage);
