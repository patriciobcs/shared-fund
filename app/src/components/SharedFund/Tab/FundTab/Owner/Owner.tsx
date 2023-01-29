function Owner(props){
    const style = {
        backgroundColor:"white",
        height:"1rem",
        marginTop:10,
        borderRadius:10,
        width:`${props.share}%`
    };
    return (
        <div>
            <label> {props.name.length > 24 ? props.name.slice(0, 24) + "..." : props.name}: {props.share} % </label>
            <div style={style} ></div>
        </div>
    )
}

export default Owner;