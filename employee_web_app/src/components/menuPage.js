import React, {Component} from 'react';
import {connect} from 'react-redux';
import {Redirect} from 'react-router-dom';
import {auth} from '../database/config';
import {initialLoad} from '../redux/actions';
import '../styles/homepage.css';
import Navbar from './navbar';
import Menu from './menu';

/** load icon from Designerz Base **/

class MenuPage extends Component {
  constructor(props) {
    super(props);
    this.state = {width: window.innerWidth};
  }

  componentDidMount() {
    this.props.initialLoad();
    window.addEventListener("resize", () => {
      this.setState({width: window.innerWidth});
    });
  }

  componentWillUnmount() {
    window.removeEventListener("resize", () => {
      this.setState({width: window.innerWidth});
    });
  }

  render() {
    if (auth.currentUser === null || auth.currentUser === undefined) {
      return (<Redirect to="/" />);
    }

    if (this.state.width >= 900) {return (<Redirect to="/Home"/>)}

    let classArray = ["displaycontainer"];
    if (this.props.loaded) {
      classArray.push("grow");
    }
    if (window.location.pathname !== "/Home") {
      classArray.push("shrink");
    }

    return (
      <div className="homepage">
        <Navbar />
        <div className={classArray.join(" ")}>
          <Menu />
        </div>
      </div>
    );
  }

}

function mapStateToProps(reduxState) {
  return {
    loaded: reduxState.loaded
  };
}

export default connect(mapStateToProps, {initialLoad})(MenuPage);
