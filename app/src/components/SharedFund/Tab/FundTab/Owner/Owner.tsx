function Owner(props){
    const style = {
        backgroundColor:"white",
        height:15,
        borderRadius:10,
        width:`${props.percentage}%`
    };
    return (
        <div>
            <label> {props.name} : {props.percentage} % </label>
            <div style={style} ></div>
        </div>
    )
}

export default Owner;