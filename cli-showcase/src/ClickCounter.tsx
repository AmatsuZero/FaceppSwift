import React, { Component } from 'react'

export default class ClickCounter extends Component<
    Readonly<{}>,
    { count: number }
> {
    constructor(props: Readonly<{}>) {
        super(props)
        this.onClickButton = this.onClickButton.bind(this)
        this.state = {
            count: 0,
        }
    }

    onClickButton() {
        this.setState({ count: this.state.count + 1 })
    }

    render(): React.ReactNode {
        return (
            <div>
                <button onClick={this.onClickButton}>Click Me</button>
                <div>Click Count: {this.state.count}</div>
            </div>
        )
    }
}
