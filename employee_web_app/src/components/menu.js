import React, {Component} from 'react';
import {connect} from 'react-redux';
import '../styles/menupage.css';
import '../styles/addclientpage.css';
import {Link} from 'react-router-dom';
import person from '../assets/person.svg';
import add from '../assets/add.svg';
import settings from '../assets/settings.svg';

class Menu extends Component {

  render() {
    var linkArray = [
      (<Link to="/Home" key="1" className="link">
        <img className="icon" src={person} alt="P" />
        <p className="menuPageTitle">Clients</p>
      </Link>),
      (<Link to="/Home/NewClient" key="2" className="link">
        <img className="icon" src={add} alt="P" />
        <p className="menuPageTitle">Add</p>
      </Link>),
      (<Link to="/Home/Settings" key="3" className="link">
        <img className="icon" src={settings} alt="P" />
        <p className="menuPageTitle">Settings</p>
      </Link>)
    ];

    let classArray1 = ["menucontainer"];
    if (window.location.pathname + "" === "/Menu") {
      classArray1.push("menuappear");
    } else {
      //console.log(this.props.loaded);
      if (this.props.loaded) {
        classArray1.push("menudisappear");
      }
    }

    return (
      <div id="menucontainer" className={classArray1.join(" ")}>
        {linkArray}
      </div>
    );
  }
}

function mapStateToProps(reduxState) {
  return {loaded: reduxState.loaded};
}

export default connect(mapStateToProps, {})(Menu);
