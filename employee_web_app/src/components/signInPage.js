import React, {Component} from 'react';
import {connect} from 'react-redux';
import {auth} from '../database/config';
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

  signIn() {
    auth.signInWithEmailAndPassword(this.state.email, this.state.password).
    then((result) => {
      this.setState({...this.state, error: false});
    })
    .catch(function(error) {
      var errorCode = error.code;
      var errorMessage = error.message;
      this.setState({...this.state, error: true})
    });
  }

  handleEmailInput(e) {
    this.setState({...this.state, email: e.target.value});
  }

  handlePasswordInput(e) {
    this.setState({...this.state, password: e.target.value});
  }

  render() {
   if (auth.currentUser != null && !this.state.error) {return (<Redirect to="/Clients" />)}
   return (
     <div className="formContainer">
      <form className="form">
        <h3>Username:</h3> <input className="textField" onChange={this.handleEmailInput} type="text"/> <br/> <br/>
        <h3>Password:</h3> <input className="textField" onChange={this.handlePasswordInput} type="text"/> <br/>
      </form>
      <div className="signInButton" onCLick={(e) => this.signIn()}>
        Sign In
      </div>
     </div>
   );
  }
}

export default connect(() => {return {}}, null)(SignInPage);
