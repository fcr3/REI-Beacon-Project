import React, {Component} from "react";
import '../style/cell.css';

class ClientInfoCell extends Component {
    constructor(props) {
        super(props);
        this.buttonClicked = this.buttonClicked.bind(this);
        this.state = {
            text: "Check In"
        }
    }

    buttonClicked(e, clicked = false) {
        debugger;
        if (clicked) {
            e.preventDefault();
            this.props.func(this.props.id);
            e.target.textContent = "Checked In"
        }
    }

    render() {
        let room = this.props.client.room
        room = room.charAt(0).toUpperCase() + room.slice(1);
        return (
            <div className="clientCell">
                <h3>Hello {this.props.client.person.split(" ")[0]}</h3>
                <div className="clientInfo">
                    <h4>
                        Meeting with {this.props.client.empName} in {room} Meeting Room. <br/> <br/>
                        Please have a seat or walk around. {"We'll be with you shortly."}
                    </h4>
                </div>
                <div className="divButton" onClick={(e) => this.buttonClicked(e, true)}>
                    {this.props.client.checkedIn === "Yes" ? "Checked In" : "Check In"}
                </div>
            </div>
        );
    }
}

export default ClientInfoCell;
