import React from 'react';

const Cell = ({title, article, link}) => (
  <li>
    <h3>{title}</h3>
    <p>{article}</p>
    <p>{link}</p>
  </li>
);

export default Cell;
