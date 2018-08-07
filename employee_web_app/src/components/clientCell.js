import React from 'react';
import '../styles/clientcell.css';

function description(client) {
  let htmlPiece = (
    <div className="description">
      Date: {client.date}<br/>Time: {client.time}
    </div>
  );
  let booleanDecision = (client.date === undefined) || (client.date === null);
  let description = booleanDecision ? null : htmlPiece;
  return description;
}

const ClientCell = ({client}) => (
  <div className="clientcell">
    <p className="title">{client.person}</p>
    {description(client)}
  </div>
);

export default ClientCell;
