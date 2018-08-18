import React from 'react';
import '../styles/clientcell.css';

function description(client) {
  let htmlPiece = (
    <div className="description">
      Date: {client.date}<br/>
      Time: {client.time}
    </div>
  );
  let booleanDecision = (client.date === undefined) || (client.date === null);
  let description = booleanDecision ? null : htmlPiece;
  return description;
}

const ClientCell = ({client, func, del}) => (
  <div className="clientcell" onClick={func}>
    <p className="title">{client.person}</p>
    <div className="infoandbutton">
      {description(client)}
      <div className="deletebox" onClick={del}>X</div>
    </div>
  </div>
);

export default ClientCell;
