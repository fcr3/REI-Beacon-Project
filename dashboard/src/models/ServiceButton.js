import React, {Component} from "react";
import '../style/button.css';

class ServiceButton extends Component {
    constructor(props) {
        super(props);
        this.buttonClicked = this.buttonClicked.bind(this);
        this.state = {
            pressed: 0
        }
    }
    
    buttonClicked(e, clicked = false) {
        if (clicked) {
            e.preventDefault();
            this.props.func();
            this.setState({
                pressed: this.state.pressed + 1
            })
        }
    }
    
    render() {
        return (
            <div onClick={(e) => this.buttonClicked(e, true)} className="button">Press for assistance</div>
        );
    }
}

export default ServiceButton;