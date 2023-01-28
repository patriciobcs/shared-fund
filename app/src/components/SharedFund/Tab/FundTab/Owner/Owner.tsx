function Owner(props){
    const style = {
        backgroundColor:"white",
        height:"1rem",
        marginTop:10,
        borderRadius:10,
        width:`${props.percentage}%`
    };
    return (
        <div>
            <label> {props.name}: {props.percentage} % </label>
            <div style={style} ></div>
        </div>
    )
}

export default Owner;