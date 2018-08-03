import React from "react";
import '../style/cell.css';

export const PlaceHolderCell = ({client}) => (
    <div className="clientCell">
        <div className="fillerInfo">
            <h3>
                Welcome to our Portland office!{client}
            </h3>
            <h4>
                If you are here for an appointment, feel free to talk to anyone
                in the office for assistance or press the green button on the
                tablet.
            </h4>
        </div>
    </div>
);
