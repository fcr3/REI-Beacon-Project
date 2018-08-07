import React, {Component} from 'react';
import {connect} from 'react-redux';
import icon from '../assets/rei-white.png';
import menuIcon from '../assets/menuIcon.png';
import '../styles/navbar.css';
import {Link} from 'react-router-dom';

class NavBar extends Component {
  constructor(props) {
    super(props);

    console.log(window.location.pathname);

    let selectedItem = ""
    let ind = 0;
    if (window.location.pathname + "" === "/Home") {selectedItem = "Clients"; ind = 0;}
    else if (window.location.pathname + "" === "/Home/NewClient") {selectedItem = "Add Client"; ind = 1}
    else {selectedItem = "Settings"}

    this.state = {
      active: false,
      width: window.innerWidth,
      height: window.innerHeight,
      selected: ind,
      selectedItem,
      link: window.location.pathname
    }
  }

  componentDidMount() {
    window.onResize = () => {
      this.setState({
        ...this.state,
        width: window.innerWidth,
        height: window.innerHeight
      })
    }
  }

  render() {
    var linkArray = [
      (<Link to="/Home" key="1" className="link">Clients</Link>),
      (<Link to="/Home/NewClient" key="2" className="link">Add Client</Link>),
      (<Link to="/Home/Settings" key="3" className="link">Settings</Link>)
    ];

    linkArray = linkArray.map((val, ind) => {
      if (ind === this.state.selected) {
        return (<Link to={this.state.link} className="link blue">{this.state.selectedItem}</Link>);
      }
      return val;
    });

    let landscapeMenu = (
      <div className="navbar">
        <img src={icon} className="menuIconLan" alt="REI Icon"/>
        <div className="menulinks">
          {linkArray}
        </div>
      </div>
    );

    let portraitMenu = (
      <div className="navbar">
        <div className="menulinks">
          {linkArray}
        </div>
        <div className="imgIcons">
          <img src={menuIcon} className="menuIconPor" alt="Menu"/>
          <img src={icon} alt="REI Icon"/>
        </div>
      </div>
    );

    if (this.state.width/this.state.height <= 4/3){return portraitMenu;}
    else {return landscapeMenu;}
  }
}

export default connect(() => {return {}}, null)(NavBar);
