import React from 'react';
import '../styles/clientcell.css';

function description(client) {
  var time = "";

  if (client.time !== undefined && client.time !== null) {
    time = client.time.split("-");
    time = time[0] + ":" + time[1] + " " + time[2];
  }

  let htmlPiece = (
    <div className="description">
      Date: {client.date}<br/>
      Time: {time}<br/>
      Location: {client.loc !== "" ? client.loc : "Unknown"}<br/>
    </div>
  );
  let booleanDecision = (client.date === undefined) || (client.date === null);
  let description = booleanDecision ? null : htmlPiece;
  return description;
}

const ClientCell = ({client, func, del, newAttr}) => (
  <div className={newAttr ? "clientcell green" : "clientcell"} onClick={func}>
    <p className="title">{client.person}</p>
    <div className="infoandbutton">
      {description(client)}
      <div className="deletebox" onClick={del}>X</div>
    </div>
  </div>
);

export default ClientCell;
