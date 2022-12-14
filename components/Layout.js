import React from "react";
import { Container } from 'semantic-ui-react';
import Header from './Header';
import 'semantic-ui-css/semantic.min.css';

const layout = (props) => {
    return <Container>
        <Header />
        {props.children}
    </Container>
}

export default layout;