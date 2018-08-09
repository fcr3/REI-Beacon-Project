import React, {Component} from 'react';
import {connect} from 'react-redux';
import icon from '../assets/rei-white.png';
import person from '../assets/person.svg';
import add from '../assets/add.svg';
import settings from '../assets/settings.svg';
import menuIcon from '../assets/menuIcon.png';
import '../styles/navbar.css';
import {Link} from 'react-router-dom';

class NavBar extends Component {
  constructor(props) {
    super(props);

    //console.log(window.location.pathname);

    let selectedItem = ""
    let ind = 0;
    let pic = null;
    if (window.location.pathname + "" === "/Home") {selectedItem = "Clients"; ind = 0; pic = person}
    else if (window.location.pathname + "" === "/Home/NewClient") {selectedItem = "Add Client"; ind = 1; pic = add}
    else if (window.location.pathname + "" === "/Home/Settings"){selectedItem = "Settings"; ind = 2; pic = settings}
    else {ind = 3;}

    this.state = {
      active: false,
      width: window.innerWidth,
      height: window.innerHeight,
      selected: ind,
      selectedItem,
      pic,
      link: window.location.pathname
    }
  }

  componentDidMount() {
    window.addEventListener("resize", () => {
      this.setState({
        ...this.state,
        width: window.innerWidth,
        height: window.innerHeight
      })
    });
  }

  render() {
    var linkArray = [
      (<Link to="/Home" key="1" className="link">
        <img className="icon" src={person} alt="P" />
        <p className="menutitle">Clients</p>
      </Link>),
      (<Link to="/Home/NewClient" key="2" className="link">
        <img className="icon" src={add} alt="P" />
        <p className="menutitle">Add Client</p>
      </Link>),
      (<Link to="/Home/Settings" key="3" className="link">
        <img className="icon" src={settings} alt="P" />
        <p className="menutitle">Settings</p>
      </Link>)
    ];

    linkArray = linkArray.map((val, ind) => {
      if (ind === this.state.selected) {
        return (
          <Link to={this.state.link} key={1 + ind + ""} className="link blue">
            <img className="icon" src={this.state.pic} alt="P" />
            <p>{this.state.selectedItem}</p>
          </Link>
        );
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
        <div className="imgIcons">
          <img src={menuIcon} className="menuIconPor2" alt="Menu"/>
          <img src={icon} className="menuIconPor1" alt="REI Icon"/>
        </div>
      </div>
    );

    if (this.state.width <= 900){return portraitMenu;}
    else {return landscapeMenu;}
  }
}

export default connect(() => {return {}}, null)(NavBar);
