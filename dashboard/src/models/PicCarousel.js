import React, {Component} from "react";
import '../style/carousel.css';
import tilikum from '../assets/tilikum.jpg';
import transit from '../assets/transit.jpg';
import park from '../assets/park.jpg';
import ziba from '../assets/ziba.jpg';

class PicCarousel extends Component {
    constructor(props) {
        super(props);
        this.state = {
            pictureArray: [tilikum, transit, park, ziba],
            index: 0
        };
    }
    
    componentDidMount() {
        setInterval(() => {
            this.setState({
               pictureArray: this.state.pictureArray,
               index: (this.state.index + 1) % this.state.pictureArray.length
            });
        }, 8000)
    }
    
    render() {
        let imageComponents = this.state.pictureArray.map((val, i) => {
            const compClasses = ['image'];
            if (i === this.state.index) {
                compClasses.push('show');
            }
            return (
                <img className={compClasses.join(' ')} alt="REI" src={this.state.pictureArray[i]} />
            );
        });
        return (
            <div className="imgContainer">
                {imageComponents}
            </div>
        );
    }
}

export default PicCarousel;
